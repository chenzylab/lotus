/**
 * 从 svgs/ 目录读取原始 SVG（对齐 semi-illustrations 的 src/svgs，MIT 协议下可直接搬运
 * 视觉资产，详见 .claude/skills/semi-porting/SKILL.md），用 svgo 清洗后逐个生成独立的
 * tsrx 插图组件。本包对应 Semi 官方的 @douyinfe/semi-illustrations（8 个场景 x 2 种
 * 明暗配色 = 16 个插图）。
 *
 * 插图与 @lotus/icons 的图标资产有本质区别：插图是多色、大尺寸（200x200）、场景化的
 * 插画，不能像图标那样把 fill 替换成 currentColor（会让颜色分层塌缩）——处理方式对齐
 * generate-icons.ts 里 MULTI_COLOR_ASSETS 白名单的思路，全量保留原始颜色。
 *
 * lotus 目前没有实现 Semi 那套"MutationObserver 监听 theme-mode 属性自动切换 image/
 * darkModeImage"的机制（不匹配 Ripple 心智模型，也不匹配 lotus 用 CSS `[data-theme]`
 * 选择器切换主题的既有方式）——因此本包亮色/暗色各自生成独立组件（IllustrationXxx /
 * IllustrationXxxDark），由消费方自行决定何时渲染哪一个，不提供自动切换能力。
 */
import { readdirSync, readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, resolve, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { optimize } from 'svgo';

const __dirname = dirname(fileURLToPath(import.meta.url));
const svgsDir = resolve(__dirname, '../svgs');
const outDir = resolve(__dirname, '../src');

/** 插图是多色场景插画，不做 currentColor 替换，只压缩路径精度、去掉固定像素宽高
 *  （交给消费方决定实际渲染尺寸）、移除生成噪音。 */
const svgoPlugins = [
  { name: 'preset-default', params: { overrides: { removeViewBox: false } } },
  { name: 'removeDimensions' },
  { name: 'removeXMLNS' },
];

interface ParsedSvg {
  viewBox: string;
  innerJsx: string;
}

function pascalCase(fileName: string): string {
  return fileName
    .replace(/\.svg$/, '')
    .split(/[-_]/)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('');
}

/** 部分插图（如 noContent）内联引用了 Semi 的品牌 CSS 变量（`--semi-color-primary`
 *  等）做强调色。lotus 的同名 token 命名规律完全对齐（仅前缀不同），直接替换前缀即可
 *  ——按 semi-porting skill 的要求，任何 `semi` 命名残留（含 CSS 变量）都必须替换。 */
function replaceSemiCssVars(svg: string): string {
  return svg.replace(/--semi-/g, '--lotus-');
}

/** 部分插图（如 noContent/failure/idle）内部用 <mask id="a"> + url(#a) 定义局部
 *  遮罩，svgo 精简后多个不同插图之间的 id 出现同名碰撞（都叫 "a"）。SVG 的 id 是
 *  文档级全局命名空间，同一页面里并列渲染两个用了相同 id 的插图时，后渲染的 <mask>
 *  定义会覆盖前一个，导致其中一个插图的遮罩失效、显示异常。用组件名做前缀让 id
 *  在跨插图场景下也能保持唯一。 */
function namespaceIds(svg: string, componentName: string): string {
  const prefix = `lotus-${componentName}`;
  return svg.replace(/\bid="([^"]+)"/g, `id="${prefix}-$1"`)
    .replace(/url\(#([^)]+)\)/g, `url(#${prefix}-$1)`)
    .replace(/xlink:href="#([^"]+)"/g, `xlink:href="#${prefix}-$1"`);
}

function extractInner(svg: string, componentName: string): ParsedSvg {
  const viewBoxMatch = svg.match(/viewBox="([^"]+)"/);
  if (!viewBoxMatch) throw new Error('SVG 缺少 viewBox 属性');
  const viewBox = viewBoxMatch[1]!;

  const innerMatch = svg.match(/<svg[^>]*>([\s\S]*)<\/svg>/);
  if (!innerMatch) throw new Error('无法解析 SVG 内部内容');
  const innerJsx = namespaceIds(replaceSemiCssVars(innerMatch[1]!.trim()), componentName);

  return { viewBox, innerJsx };
}

function generateComponent(componentName: string, parsed: ParsedSvg): string {
  const header = `/**
 * 插图资源移植自 Semi Design（MIT License），viewBox/path 数据与原始配色保留（多色
 * 场景插画，不做 currentColor 替换），组件名按 @lotus/illustrations 命名规范重写。
 * 详见 .claude/skills/semi-porting/SKILL.md。
 */`;
  return `${header}
export function ${componentName}(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="${parsed.viewBox}"
        fill="none"
        width={200}
        height={200}
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
    const result = optimize(raw, { plugins: svgoPlugins });
    if (result.data === undefined) {
      throw new Error(`svgo 优化失败: ${svgFile}`);
    }

    const componentName = `Illustration${pascalCase(basename(svgFile))}`;
    const parsed = extractInner(result.data, componentName);
    const componentSource = generateComponent(componentName, parsed);

    const outFileName = `${componentName}.tsrx`;
    writeFileSync(resolve(outDir, outFileName), componentSource, 'utf-8');
    generated.push({ fileName: outFileName, componentName });
    console.log(`  生成 ${outFileName}`);
  }

  if (generated.length !== svgFiles.length) {
    throw new Error(`生成数量不匹配：源文件 ${svgFiles.length} 个，实际生成 ${generated.length} 个`);
  }

  const barrel = generated
    .map(({ fileName, componentName }) => `export { ${componentName} } from './${fileName}';`)
    .join('\n');
  writeFileSync(resolve(outDir, 'index.ts'), `${barrel}\n`, 'utf-8');

  console.log(`[illustrations] 共生成 ${generated.length} 个插图组件，写入 ${outDir}`);
}

main();
