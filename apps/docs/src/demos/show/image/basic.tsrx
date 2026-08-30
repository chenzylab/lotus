import { Image } from '@lotus/ripple';

const DEMO_SRC =
    'data:image/svg+xml;base64,' +
    btoa(
        unescape(
            encodeURIComponent(
                '<svg xmlns="http://www.w3.org/2000/svg" width="240" height="160">' +
                    '<rect width="240" height="160" fill="#dbeafe"/>' +
                    '<circle cx="120" cy="80" r="50" fill="#60a5fa"/>' +
                    '</svg>',
            ),
        ),
    );

export function BasicImageDemo() @{
    <Image src={DEMO_SRC} width={240} height={160} alt="示例图片" aria-label="基础 Image，点击可预览" />
}
