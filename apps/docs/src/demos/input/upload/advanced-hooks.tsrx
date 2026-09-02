import { track } from 'ripple';
import { Upload, Button, TypographyText, type FileItem, type CustomRequestArgs } from '@lotus/ripple';

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

export function AdvancedHooksUploadDemo() @{
    let &[fileList] = track<FileItem[]>([]);
    let &[log] = track<string>('');
    let &[customFileList] = track<FileItem[]>([
        { uid: 'demo-1', name: 'report.pdf', size: 20480, status: 'success', percent: 100 },
    ]);

    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <Upload
            action="https://example.com/upload"
            customRequest={mockUploadRequest}
            multiple
            showClear
            maxSize={5000}
            prompt="支持任意文件，单个文件不超过 5MB"
            promptPosition="bottom"
            fileList={fileList}
            onChange={(list) => { fileList = list; }}
            beforeRemove={(file) => { log = `尝试移除：${file.name}`; return true; }}
            beforeClear={() => { log = '尝试清空'; return true; }}
            onClear={() => { log = '已清空'; }}
            onSizeError={(file) => { log = `文件过大：${file.name}`; }}
            onPreviewClick={(file) => { log = `预览：${file.name}`; }}
            aria-label="Upload beforeRemove 高级钩子演示"
        />
        <TypographyText type="secondary" aria-label="Upload 高级钩子事件日志">{log}</TypographyText>

        <Upload
            action="https://example.com/upload"
            customRequest={mockUploadRequest}
            fileList={customFileList}
            onChange={(list) => { customFileList = list; }}
            renderFileItem={(props) => (
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '8px', border: '1px dashed var(--lotus-color-primary)' }}>
                    <span>★ {props.name}（{props.status}）</span>
                    <Button size="small" theme="borderless" onClick={props.onRemove}>移除</Button>
                </div>
            )}
            aria-label="Upload renderFileItem 演示"
        />
    </div>
}
