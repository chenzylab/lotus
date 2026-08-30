import { track } from 'ripple';
import { Upload, TypographyText, type CustomRequestArgs } from '@lotus/ripple';

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

export function LimitUploadDemo() @{
    let &[log] = track<string>('');

    <div>
        <Upload
            action="https://example.com/upload"
            customRequest={mockUploadRequest}
            multiple
            limit={2}
            maxSize={5000}
            onExceed={() => { log = '超出数量限制'; }}
            aria-label="Upload 限制"
        />
        <TypographyText type="secondary" aria-label="Upload 限制事件日志">{log}</TypographyText>
    </div>
}
