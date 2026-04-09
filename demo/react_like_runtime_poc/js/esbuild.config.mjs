import esbuild from 'esbuild';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const rootDir = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.resolve(rootDir, '../assets/bundles');

await esbuild.build({
  bundle: true,
  entryPoints: {
    bundle_a: path.resolve(rootDir, 'src/apps/bundleA.tsx'),
    bundle_b: path.resolve(rootDir, 'src/apps/bundleB.tsx'),
  },
  format: 'iife',
  jsxFactory: 'createElement',
  outfile: undefined,
  outdir: outDir,
  platform: 'browser',
  sourcemap: false,
  target: ['es2020'],
});
