import { track } from 'ripple';
import { Upload, type FileItem, type CustomRequestArgs } from '@lotus/ripple';

function mockUploadRequest(args: CustomRequestArgs) {
    let percent = 0;
    const timer = setInterval(() => {
        percent += 20;
        if (percent >= 100) {
            clearInterval(timer);
            args.onProgress(100);
            args.onSuccess({ url: `https://example.com/${args.fileName}` });
            return;
        }
        args.onProgress(percent);
    }, 200);
}

export function UploadCropDemo() @{
    let &[fileList] = track<FileItem[]>([]);

    <Upload
        action="https://example.com/upload"
        customRequest={mockUploadRequest}
        listType="picture"
        crop
        fileList={fileList}
        onChange={(list) => { fileList = list; }}
        aria-label="Upload crop 图片裁剪示例"
    />
}
