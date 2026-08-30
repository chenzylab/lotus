import { track } from 'ripple';
import { Cropper, Button, type CropperApi } from '@lotus/ripple';

// 同源 SVG data URI：跨域图片会污染 canvas，getImageData/toDataURL 会被浏览器拒绝
// （SecurityError: The canvas has been tainted by cross-origin data），改用同源资源规避。
const DEMO_SRC =
    'data:image/svg+xml;base64,' +
    btoa(
        unescape(
            encodeURIComponent(
                '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600">' +
                    '<rect width="800" height="600" fill="#eef2ff"/>' +
                    '<circle cx="250" cy="300" r="180" fill="#60a5fa"/>' +
                    '<rect x="450" y="120" width="280" height="360" fill="#f472b6"/>' +
                    '<text x="400" y="580" font-size="28" text-anchor="middle" fill="#1e293b">lotus cropper demo</text>' +
                    '</svg>',
            ),
        ),
    );

export function BasicCropperDemo() @{
    let &[resultUrl] = track<string>('');
    let apiRef: CropperApi | undefined;

    <div style={{ display: 'flex', gap: '16px', alignItems: 'flex-start' }}>
        <div style={{ width: '300px', height: '220px' }}>
            <Cropper
                src={DEMO_SRC}
                style={{ width: '100%', height: '100%' }}
                getCropperApi={(api) => { apiRef = api; }}
                aria-label="基础 Cropper"
            />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <Button onClick={() => { const canvas = apiRef?.getCropperCanvas(); if (canvas) resultUrl = canvas.toDataURL(); }}>
                获取裁切结果
            </Button>
            @if (resultUrl) {
                <img src={resultUrl} aria-label="Cropper 导出预览" style={{ width: '150px', border: '1px solid var(--lotus-color-border)' }} />
            }
        </div>
    </div>
}
