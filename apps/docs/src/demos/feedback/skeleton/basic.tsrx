import { Skeleton, SkeletonAvatar, SkeletonImage, SkeletonTitle, SkeletonParagraph, SkeletonButton, Switch, Avatar, Button } from '@lotus/ripple';
import { track } from 'ripple';

export function BasicSkeletonDemo() {
    let &[loading] = track<boolean>(true);

    return <div>
        <span style={{ display: 'flex', alignItems: 'center' }}>
            <Switch checked={loading} onChange={(checked: boolean) => { loading = checked; }} />
            <span style={{ marginLeft: '10px' }}>显示加载内容</span>
        </span>
        <br />
        <Skeleton placeholder={<SkeletonAvatar />} loading={loading}>
            <Avatar color="blue" style={{ marginBottom: '10px' }}>U</Avatar>
        </Skeleton>
        <br />
        <Skeleton style={{ width: '200px', height: '150px' }} placeholder={<SkeletonImage />} loading={loading}>
            <img
                src="https://lf3-static.bytednsdoc.com/obj/eden-cn/ptlz_zlp/ljhwZthlaukjlkulzlp/root-web-sites/dy.png"
                height="150"
                alt="avatar"
            />
        </Skeleton>
        <br />
        <Skeleton
            style={{ width: '80px' }}
            placeholder={<SkeletonTitle style={{ marginBottom: '10px' }} />}
            loading={loading}
        >
            <h4 style={{ marginBottom: '0' }}>Lotus UI</h4>
        </Skeleton>
        <Skeleton style={{ width: '240px' }} placeholder={<SkeletonParagraph rows={2} />} loading={loading}>
            <p style={{ width: '240px' }}>精心打磨每一个组件的用户体验，从用户的角度考虑每个组件的使用场景。</p>
        </Skeleton>
        <br />
        <Skeleton placeholder={<SkeletonButton />} loading={loading}>
            <Button>Button</Button>
        </Skeleton>
    </div>;
}
