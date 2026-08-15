/**
 * 从 svgs/ 目录读取原始 SVG（对齐 semi-icons 的 src/svgs，MIT 协议下可直接搬运视觉资产，
 * 详见 .claude/skills/semi-porting/SKILL.md），用 svgo 清洗后逐个生成独立的 tsrx 图标组件。
 * 本包对应 Semi 官方的 @douyinfe/semi-icons（523 个正式图标），实验性图标另见
 * @lotus/icons-lab（对应 semi-icons-lab 84 个）——拆成两个独立包是为了与 Semi 官方
 * 包结构保持一致，同时避免两批图标合并到同一目录时因同名文件
 * （calendar/image/list/radio/spin/upload）互相覆盖。
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

/** svgo 清洗规则：黑色 fill 替换为 currentColor（继承文字色），压缩路径精度，去掉固定像素宽高
 *  （让 viewBox 保留、由消费方决定实际渲染尺寸），移除生成噪音（class/style 属性等）。
 *  插件选择参考 semi-icons/scripts/build-icon.js 的思路，非逐项照抄。
 *
 *  不适用于 MULTI_COLOR_ASSETS 白名单里的文件——见该常量注释（对应 icons-lab 踩坑 #27
 *  的同类问题：把"故意多彩/渐变设计"的图标当成单色线框图标做 currentColor 替换，会让
 *  颜色塌缩、丢失视觉分层）。 */
const commonSvgoPlugins = [
    { name: 'preset-default', params: { overrides: { removeViewBox: false } } },
    { name: 'removeDimensions' },
    { name: 'removeXMLNS' },
];
const svgoPlugins = [...commonSvgoPlugins, { name: 'convertColors', params: { currentColor: /^(?!url|none)./ } }];

/** 故意设计成多彩/渐变的图标文件名清单，不做 currentColor 替换，完整保留原始颜色。
 *  当前收录 AI 等级系列（ai_*_level_2/_level_3，共 16 个）：level_2 是黑色主体 +
 *  紫色 `#A647FF` 强调色的双色设计，level_3 用 `<linearGradient>` 定义四档渐变
 *  （`#E945FF → #A647FF → #6B61FF → #2E8CFF`），都是 AI 功能等级的品牌标识色，
 *  替换成 currentColor 会让强调色/渐变塌缩成主体色，丢失设计意图。level_1 是纯黑
 *  单色，不在此列，走正常的 currentColor 继承色路径。
 *
 *  `ai_loading.svg` 同属此类但初次排查时漏掉——它用 `stroke="url(#gradient)"`
 *  引用同一套 AI 品牌渐变色，而不是 `fill="url(...)"`，人工抽查颜色时只看了
 *  `fill` 属性没看 `stroke`，属于检查方法本身的盲区（见 specs 踩坑 #27 补充二）。
 *
 *  新增类似多彩图标时在此登记，登记前务必同时检查 `fill` 和 `stroke` 上的
 *  `url(#...)` 渐变引用，不能只查 `fill`。 */
const MULTI_COLOR_ASSETS = new Set([
    'ai_bell_level_2.svg', 'ai_bell_level_3.svg',
    'ai_edit_level_2.svg', 'ai_edit_level_3.svg',
    'ai_file_level_2.svg', 'ai_file_level_3.svg',
    'ai_filled_level_2.svg', 'ai_filled_level_3.svg',
    'ai_image_level_2.svg', 'ai_image_level_3.svg',
    'ai_search_level_2.svg', 'ai_search_level_3.svg',
    'ai_stroked_level_2.svg', 'ai_stroked_level_3.svg',
    'ai_wand_level_2.svg', 'ai_wand_level_3.svg',
    'ai_loading.svg',
]);
function isMultiColorAsset(svgFileName: string): boolean {
    return MULTI_COLOR_ASSETS.has(svgFileName);
}

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
function extractInner(svg: string, skipColorWarning: boolean): ParsedSvg {
    const viewBoxMatch = svg.match(/viewBox="([^"]+)"/);
    if (!viewBoxMatch) throw new Error('SVG 缺少 viewBox 属性');
    const viewBox = viewBoxMatch[1]!;

    const innerMatch = svg.match(/<svg[^>]*>([\s\S]*)<\/svg>/);
    if (!innerMatch) throw new Error('无法解析 SVG 内部内容');
    let innerJsx = innerMatch[1]!.trim();

    // svgo 输出的自闭合标签已经是 XML 规范的 `/>`，与 JSX 自闭合语法一致，无需转换。
    // 仅需处理 fill="black"/"#000" 等未被 convertColors 命中的残留颜色值——理论上
    // svgoPlugins 已覆盖，这里做一次防御性兜底校验（不做替换，只报警，避免静默产出
    // 未继承 currentColor 的图标）。MULTI_COLOR_ASSETS 白名单文件跳过这条警告——
    // 它们的黑色 fill 是有意保留的主体色，不是遗漏。
    if (!skipColorWarning && /fill="#000000?"|fill="black"/i.test(innerJsx)) {
        console.warn(`  [警告] 检测到未被 currentColor 替换的黑色 fill，请检查 svgo 插件配置`);
    }

    return { viewBox, innerJsx };
}

/** lotus 自有原创资产文件名清单（非 Semi 移植），头部注释需要区分说明，
 *  避免自创图标被误标注为"移植自 Semi"。新增自有图标时在此登记。 */
const OWN_ASSETS = new Set(['lotus_logo.svg']);
function isOwnAsset(svgFileName: string): boolean {
    return OWN_ASSETS.has(svgFileName);
}

function generateComponent(componentName: string, parsed: ParsedSvg, ownAsset: boolean): string {
    const header = ownAsset
        ? `/**
 * lotus 自有原创图标资产（非 Semi 移植）。
 */`
        : `/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */`;
    return `${header}
export function ${componentName}(props: { class?: string; style?: Record<string, any> }) {
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
        ${parsed.innerJsx}
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
        const multiColor = isMultiColorAsset(svgFile);
        const result = optimize(raw, { plugins: multiColor ? commonSvgoPlugins : svgoPlugins });
        if (result.data === undefined) {
            throw new Error(`svgo 优化失败: ${svgFile}`);
        }

        const componentName = `Icon${pascalCase(basename(svgFile))}`;
        const parsed = extractInner(result.data, multiColor);
        const componentSource = generateComponent(componentName, parsed, isOwnAsset(svgFile));

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
