import { CodeHighlight } from '@lotus/ripple';

const SAMPLE = `function greet(name) {
  return \`Hello, \${name}!\`;
}`;

export function BasicCodeHighlightDemo() @{
    <CodeHighlight code={SAMPLE} language="javascript" />
}
