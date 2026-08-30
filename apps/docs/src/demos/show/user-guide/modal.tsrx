import { track } from 'ripple';
import { UserGuide, Button } from '@lotus/ripple';

export function ModalUserGuideDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button size="small" onClick={() => { visible = true; }}>打开 modal 引导</Button>
        <UserGuide
            mode="modal"
            visible={visible}
            steps={[
                { title: '欢迎使用 lotus', description: 'lotus 是对齐 Semi Design 能力的 Ripple 组件库。' },
                { title: '功能强大', description: '涵盖基础、导航、数据录入、数据展示等多个分类的组件。' },
                { title: '开始使用', description: '点击完成关闭本引导，开始探索吧。' },
            ]}
            onFinish={() => { visible = false; }}
            onSkip={() => { visible = false; }}
            aria-label="modal UserGuide"
        />
    </div>
}
