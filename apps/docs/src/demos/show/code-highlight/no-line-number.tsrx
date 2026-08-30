import { CodeHighlight } from '@lotus/ripple';

const SAMPLE = `.lotus-button {
  border-radius: var(--lotus-border-radius-medium);
}`;

export function NoLineNumberCodeHighlightDemo() @{
    <CodeHighlight code={SAMPLE} language="css" lineNumber={false} />
}
