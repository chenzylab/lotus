export type SpaceAlign = 'start' | 'center' | 'end' | 'baseline';
export type SpaceSpacingKeyword = 'loose' | 'medium' | 'tight';
export type SpaceSpacing = SpaceSpacingKeyword | number | [SpaceSpacingKeyword | number, SpaceSpacingKeyword | number];

export interface SpaceProps {
    children?: any;
    wrap?: boolean;
    align?: SpaceAlign;
    vertical?: boolean;
    spacing?: SpaceSpacing;
    style?: Record<string, any>;
    class?: string;
}

const SPACING_TOKEN: Record<SpaceSpacingKeyword, string> = {
    tight: 'var(--lotus-spacing-tight)',
    medium: 'var(--lotus-spacing-base)',
    loose: 'var(--lotus-spacing-loose)',
};

function resolveSpacingValue(value: SpaceSpacingKeyword | number): string {
    return typeof value === 'number' ? `${value}px` : SPACING_TOKEN[value];
}

export function Space(&{
    children,
    wrap = false,
    align = 'center',
    vertical = false,
    spacing = 'tight',
    style,
    class: className,
}: SpaceProps) @{
    // 数组形式 [水平间距, 垂直间距]（对齐 Semi 的 spacing={[8, 16]} 语义）；
    // 单值形式两个方向共用同一间距。
    const [horizontalSpacing, verticalSpacing] = Array.isArray(spacing) ? spacing : [spacing, spacing];
    const gapValue = `${resolveSpacingValue(verticalSpacing)} ${resolveSpacingValue(horizontalSpacing)}`;
    const classes = ['lotus-space', vertical ? 'lotus-space-vertical' : 'lotus-space-horizontal', className ?? '']
        .filter(Boolean)
        .join(' ');

    <>
        <div
            class={classes}
            style={{
                ...style,
                gap: gapValue,
                flexWrap: wrap ? 'wrap' : 'nowrap',
                alignItems: align,
            }}
        >
            {children}
        </div>

        <style>
            .lotus-space {
                display: inline-flex;
                box-sizing: border-box;
            }

            .lotus-space-horizontal {
                flex-direction: row;
            }

            .lotus-space-vertical {
                flex-direction: column;
            }
        </style>
    </>
}
