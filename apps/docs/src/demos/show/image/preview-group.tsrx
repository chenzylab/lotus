import { Image, ImagePreviewGroup } from '@lotus/ripple';

function svgSrc(color: string) {
    return 'data:image/svg+xml;base64,' +
        btoa(
            unescape(
                encodeURIComponent(
                    `<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120"><rect width="120" height="120" fill="${color}"/></svg>`,
                ),
            ),
        );
}

export function PreviewGroupImageDemo() @{
    <ImagePreviewGroup>
        <div style={{ display: 'flex', gap: '8px' }}>
            <Image src={svgSrc('%2360a5fa')} width={100} height={100} alt="图片一" aria-label="预览组图片一" />
            <Image src={svgSrc('%23f472b6')} width={100} height={100} alt="图片二" aria-label="预览组图片二" />
            <Image src={svgSrc('%2334d399')} width={100} height={100} alt="图片三" aria-label="预览组图片三" />
        </div>
    </ImagePreviewGroup>
}
