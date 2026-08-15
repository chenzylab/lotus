import { Divider } from '@lotus/ripple';

export function BasicDividerDemo() {
    return <div>
        <h3>水平实线</h3>
        <span>lotus 是一个组件库。</span>
        <Divider margin="12px" />
        <span>它定义了一套中后台设计与前端基础组件。</span>

        <h3 style={{ marginTop: '40px' }}>水平虚线</h3>
        <span>lotus 是一个组件库。</span>
        <Divider dashed margin="12px" />
        <span>它定义了一套中后台设计与前端基础组件。</span>

        <h3 style={{ marginTop: '40px' }}>垂直实线</h3>
        <div>
            <span>左</span>
            <Divider layout="vertical" margin="12px" />
            <span>中</span>
            <Divider layout="vertical" margin="12px" />
            <span>右</span>
        </div>

        <h3 style={{ marginTop: '40px' }}>垂直虚线</h3>
        <div>
            <span>左</span>
            <Divider layout="vertical" dashed margin="12px" />
            <span>中</span>
            <Divider layout="vertical" dashed margin="12px" />
            <span>右</span>
        </div>
    </div>;
}
