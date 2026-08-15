/**
 * 从 svgs/ 目录读取原始 SVG（对齐 semi-icons-lab 的 src/svgs，MIT 协议下可直接搬运视觉资产，
 * 详见 .claude/skills/semi-porting/SKILL.md），用 svgo 清洗后逐个生成独立的 tsrx 图标组件。
 * 本包对应 Semi 官方的 @douyinfe/semi-icons-lab（84 个实验性图标），与 @lotus/icons
 * （对应 semi-icons 523 个正式图标）拆成两个独立包，保持与 Semi 官方包结构一致，
 * 避免两批图标合并到同一目录时因同名文件（calendar/image/list/radio/spin/upload）互相覆盖。
 *
 * 与 Semi 官方 `scripts/build-svg.js` 的核心差异：
 * 1. 目标语言是 tsrx 不是 React，生成的是 `export function IconXxx()` 而非
 *    `convertIcon(SvgComponent, type)` 包一层的双层结构——lotus 图标组件不需要
 *    Semi 那套 size/spin/rotate/fill 数组等运行时能力，尺寸/旋转交给调用方用
 *    style/class 控制（对齐现有组件里手写内联 SVG 的一贯做法）。
 * 2. 不依赖任何外部 <style> 类名（踩坑 #23：跨文件复用的 class 若不能保证消费方
 *    一定引用了定义它的文件，样式会静默缺失）——图标组件把 aria-hidden 等固定
 *    属性直接写进 JSX，不引入 CSS class。
 */
import { readdirSync, readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, resolve, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { optimize } from 'svgo';

const __dirname = dirname(fileURLToPath(import.meta.url));
const svgsDir = resolve(__dirname, '../svgs');
const outDir = resolve(__dirname, '../src');

/** svgo 清洗规则：压缩路径精度，去掉固定像素宽高（让 viewBox 保留、由消费方决定实际渲染
 *  尺寸），移除生成噪音（class/style 属性等）。
 *
 *  与 @lotus/icons（主包）的关键差异：这里 **不** 做 currentColor 颜色替换。icons-lab
 *  对应 Semi 官方 semi-icons-lab——这批图标是故意设计成多彩徽标风格（如 avatar.svg 的
 *  橙黄底+白色人像剪影、mask 镂空效果等），每个图标内部有多个不同的固定色值，替换成单一
 *  currentColor 会让所有色块塌缩成同一个颜色，abstract mask/镂空细节在视觉上完全消失
 *  （真机验证时曾把 IconAvatar 等图标误判为纯黑块，即为此问题）。保留原始多色 fill 值，
 *  与 Semi 官方 semi-icons-lab 的渲染效果一致。 */
const svgoPlugins = [
    { name: 'preset-default', params: { overrides: { removeViewBox: false } } },
    { name: 'removeDimensions' },
    { name: 'removeXMLNS' },
];

interface ParsedSvg {
    viewBox: string;
    /** SVG 内部子元素的 JSX 字符串（已把 kebab-case 属性名转成 tsrx 支持的字符串键写法）。 */
    innerJsx: string;
}

function pascalCase(fileName: string): string {
    return fileName
        .replace(/\.svg$/, '')
        .split(/[_-]/)
        .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
        .join('');
}

/** 把 svgo 输出的属性字符串规整成 tsrx JSX 可接受的写法：kebab-case 属性名原样保留
 *  （tsrx 支持 `stroke-width="1.2"` 这种字符串字面量写法，已在其余组件验证过），
 *  纯粹是把双引号属性值透传，不做属性名转换。 */
function extractInner(svg: string): ParsedSvg {
    const viewBoxMatch = svg.match(/viewBox="([^"]+)"/);
    if (!viewBoxMatch) throw new Error('SVG 缺少 viewBox 属性');
    const viewBox = viewBoxMatch[1]!;

    const innerMatch = svg.match(/<svg[^>]*>([\s\S]*)<\/svg>/);
    if (!innerMatch) throw new Error('无法解析 SVG 内部内容');
    let innerJsx = innerMatch[1]!.trim();

    // svgo 输出的自闭合标签已经是 XML 规范的 `/>`，与 JSX 自闭合语法一致，无需转换。
    // icons-lab 故意保留原始多色 fill 值（见 svgoPlugins 注释），不做 currentColor 替换。

    return { viewBox, innerJsx };
}

/** 检测 SVG 内容里所有本地 `id="xxx"` 声明（`<mask>`/`<linearGradient>`/
 *  `<clipPath>` 等常用来定义局部引用目标），返回去重后的 id 列表。svgo 生成的
 *  id 是固定字符串（如 `mask id="a"`），同一图标组件在同一页面渲染多个实例时
 *  会产生重复 id，违反 HTML "id 全文档唯一" 约束，`url(#id)` 引用行为在有多个
 *  同 id 元素时并不总是可预测。 */
function extractLocalIds(innerJsx: string): string[] {
    const ids = new Set<string>();
    for (const match of innerJsx.matchAll(/\bid="([^"]+)"/g)) {
        ids.add(match[1]!);
    }
    return [...ids];
}

/** 把 innerJsx 里每个本地 id 的声明处（`id="x"`）和引用处（`url(#x)`）都替换成
 *  基于组件内 `uid` 变量的模板字符串插值，避免多实例渲染时 id 冲突。 */
function makeIdsUnique(innerJsx: string, ids: string[]): string {
    let result = innerJsx;
    for (const id of ids) {
        const escaped = id.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        result = result
            .replace(new RegExp(`id="${escaped}"`, 'g'), `id={\`\${uid}-${id}\`}`)
            .replace(new RegExp(`url\\(#${escaped}\\)`, 'g'), `url(#\${uid}-${id})`);
        // 上面第二步会把 `url(#x)` 出现在普通字符串属性值里的场景（如
        // `mask="url(#x)"`）错误保留为字面量——统一改成模板字符串属性写法。
        result = result.replace(
            new RegExp(`="url\\(#\\\${uid}-${id}\\)"`, 'g'),
            `={\`url(#\${uid}-${id})\`}`,
        );
    }
    return result;
}

function generateComponent(componentName: string, parsed: ParsedSvg): string {
    const localIds = extractLocalIds(parsed.innerJsx);
    const innerJsx = localIds.length > 0 ? makeIdsUnique(parsed.innerJsx, localIds) : parsed.innerJsx;
    const uidSetup = localIds.length > 0
        ? `\n    const uid = \`lotus-${componentName.toLowerCase()}-\${uidCounter++}\`;`
        : '';
    const uidCounterDecl = localIds.length > 0
        ? `/** 模块级自增计数器，为每次渲染生成唯一的本地 id 后缀（见 extractLocalIds/makeIdsUnique）。 */\nlet uidCounter = 0;\n\n`
        : '';
    return `${uidCounterDecl}/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function ${componentName}(props: { class?: string; style?: Record<string, any> }) {${uidSetup}
    return <svg
        viewBox="${parsed.viewBox}"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        ${innerJsx}
    </svg>;
}
`;
}

function main(): void {
    if (!existsSync(svgsDir)) {
        throw new Error(`源目录不存在: ${svgsDir}`);
    }
    mkdirSync(outDir, { recursive: true });

    const svgFiles = readdirSync(svgsDir).filter((f) => f.endsWith('.svg'));
    if (svgFiles.length === 0) {
        throw new Error(`${svgsDir} 下没有找到任何 .svg 文件`);
    }

    const generated: Array<{ fileName: string; componentName: string }> = [];

    for (const svgFile of svgFiles) {
        const raw = readFileSync(resolve(svgsDir, svgFile), 'utf-8');
        const result = optimize(raw, { plugins: svgoPlugins });
        if (result.data === undefined) {
            throw new Error(`svgo 优化失败: ${svgFile}`);
        }

        const componentName = `Icon${pascalCase(basename(svgFile))}`;
        const parsed = extractInner(result.data);
        const componentSource = generateComponent(componentName, parsed);

        const outFileName = `${componentName}.tsrx`;
        writeFileSync(resolve(outDir, outFileName), componentSource, 'utf-8');
        generated.push({ fileName: outFileName, componentName });
        console.log(`  生成 ${outFileName}`);
    }

    // 数量校验：生成的组件数量必须与源 SVG 数量精确一致，防止流程静默跳过文件
    // （对应 specs/phases/phase-1-basic-form.spec.md 验收标准）。
    if (generated.length !== svgFiles.length) {
        throw new Error(`生成数量不匹配：源文件 ${svgFiles.length} 个，实际生成 ${generated.length} 个`);
    }

    const barrel = generated
        .map(({ fileName, componentName }) => `export { ${componentName} } from './${fileName}';`)
        .join('\n');
    writeFileSync(resolve(outDir, 'index.ts'), `${barrel}\n`, 'utf-8');

    console.log(`[icons] 共生成 ${generated.length} 个图标组件，写入 ${outDir}`);
}

main();
