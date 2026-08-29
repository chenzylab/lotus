/**
 * 验证 @lotus/icons 支持按需引入：用真实的 Vite + ripple 插件构建一个只
 * import 单个图标的最小入口，产物体积应远小于把全部 524 个图标都打包进去的
 * 体积——证明具名导出的 barrel file（每个图标独立 .tsrx 文件）确实能被
 * tree-shaking 摇掉未使用的图标，而不是靠肉眼观察"结构上看起来支持"就
 * 假设它真的生效（对应 specs/phases/phase-1-basic-form.spec.md 验收标准）。
 *
 * 不用 vitest 单测跑这个验证——这是"跑一次真实构建、量产物体积"的构建流程
 * 校验，不是纯函数逻辑测试，放进常规单测套件会引入不必要的构建耗时。
 */
import { build } from 'vite';
import { rmSync, mkdirSync, writeFileSync, readdirSync, statSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const scratchDir = resolve(__dirname, '.tree-shaking-check');
const outDir = resolve(scratchDir, 'dist');

function dirSize(dir: string): number {
  let total = 0;
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = resolve(dir, entry.name);
    total += entry.isDirectory() ? dirSize(full) : statSync(full).size;
  }
  return total;
}

/** 统计产物里出现的图标函数定义数量——比字节数更直接：字节数会被 ripple
 * 运行时的固定注入体积（hydration/operations 等内部模块，随图标数量不
 * 变）掩盖真实差异，图标函数定义数量则是精确的、不受这个固定开销干扰的
 * 信号。 */
function countIconFunctions(dir: string): number {
  const bundlePath = resolve(dir, 'bundle.js');
  const source = readFileSync(bundlePath, 'utf-8');
  const matches = source.match(/function Icon[A-Za-z0-9]*\(/g) ?? [];
  return new Set(matches).size;
}

async function buildEntry(entrySource: string, outSubDir: string): Promise<{ size: number; iconCount: number }> {
  const entryFile = resolve(scratchDir, 'entry.ts');
  writeFileSync(entryFile, entrySource, 'utf-8');
  const thisOutDir = resolve(outDir, outSubDir);

  await build({
    configFile: false,
    logLevel: 'silent',
    plugins: [(await import('@ripple-ts/vite-plugin')).ripple()],
    resolve: { alias: { '@lotus/icons': resolve(__dirname, '../src/index.ts') } },
    build: {
      write: true,
      outDir: thisOutDir,
      emptyOutDir: true,
      minify: false,
      lib: { entry: entryFile, formats: ['es'], fileName: () => 'bundle.js' },
    },
  });

  return { size: dirSize(thisOutDir), iconCount: countIconFunctions(thisOutDir) };
}

async function main(): Promise<void> {
  rmSync(scratchDir, { recursive: true, force: true });
  mkdirSync(scratchDir, { recursive: true });

  try {
    const single = await buildEntry(
      `import { IconActivity } from '@lotus/icons';\nexport { IconActivity };\n`,
      'single',
    );
    const all = await buildEntry(
      `export * from '@lotus/icons';\n`,
      'all',
    );

    console.log(`[verify-tree-shaking] 单图标引入：产物 ${single.size} 字节，含 ${single.iconCount} 个图标函数定义`);
    console.log(`[verify-tree-shaking] 全量引入：产物 ${all.size} 字节，含 ${all.iconCount} 个图标函数定义`);

    // 核心校验：只 import 一个图标时，产物里应该只出现这一个图标的函数
    // 定义——如果 tree-shaking 没生效，会看到全部 524 个图标函数都被打包
    // 进来（哪怕字节数因 ripple 运行时固定开销而看不出明显差异）。
    if (single.iconCount !== 1) {
      throw new Error(
        `按需引入未生效：只 import IconActivity 一个图标，产物里却出现了 ${single.iconCount} 个图标函数定义，` +
        `说明 tree-shaking 没有把未使用的图标摇掉`,
      );
    }
    if (all.iconCount < 500) {
      throw new Error(`全量引入的验证基准本身不对：预期 524 个左右图标函数，实际只有 ${all.iconCount} 个，请检查测试脚本`);
    }
    if (single.size >= all.size) {
      throw new Error(`单图标产物体积（${single.size}）不应大于等于全量产物体积（${all.size}）`);
    }
    console.log('[verify-tree-shaking] 通过：按需引入确认生效，单图标产物只含目标图标本身');
  } finally {
    rmSync(scratchDir, { recursive: true, force: true });
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
