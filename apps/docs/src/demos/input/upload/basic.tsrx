import { track } from 'ripple';
import { Upload, TypographyText, type FileItem, type CustomRequestArgs } from '@lotus/ripple';

/**
 * 文档站演示环境不发起真实网络请求，用 customRequest 模拟上传进度与结果
 * （对齐 playground 的 mockUploadRequest 写法）。
 */
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

export function BasicUploadDemo() @{
    let &[fileList] = track<FileItem[]>([]);
    let &[log] = track<string>('');

    <div>
        <Upload
            action="https://example.com/upload"
            customRequest={mockUploadRequest}
            fileList={fileList}
            onChange={(list) => { fileList = list; log = `变化：${list.length} 个文件`; }}
            aria-label="Upload 基础"
        />
        <TypographyText type="secondary" aria-label="Upload 事件日志">{log}</TypographyText>
    </div>
}
