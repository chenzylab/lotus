import { track } from 'ripple';
import { Button, Upload, type FileItem, type CustomRequestArgs } from '@lotus/ripple';

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

export function UploadCustomTriggerDemo() @{
    let &[fileList] = track<FileItem[]>([]);

    <Upload
        action="https://example.com/upload"
        customRequest={mockUploadRequest}
        listType="picture"
        showPicInfo
        fileList={fileList}
        onChange={(list) => { fileList = list; }}
        fileListTitle="我的图片"
        renderPicClose={({ remove }) => <Button size="small" theme="borderless" onClick={remove}>移除</Button>}
        aria-label="Upload 自定义触发区示例"
    >
        <Button>自定义上传按钮</Button>
    </Upload>
}
