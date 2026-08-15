import { Skeleton, SkeletonImage, SkeletonTitle } from '@lotus/ripple';

export function CombineImageTitleSkeletonDemo() {
    const placeholder = <div>
        <SkeletonImage style={{ width: '200px', height: '150px' }} />
        <SkeletonTitle style={{ width: '120px', marginTop: '10px' }} />
    </div>;

    return <Skeleton placeholder={placeholder} loading={true}>
        <img
            src="https://lf3-static.bytednsdoc.com/obj/eden-cn/ptlz_zlp/ljhwZthlaukjlkulzlp/root-web-sites/dy.png"
            height="150"
            alt="avatar"
        />
        <h4>Lotus UI</h4>
    </Skeleton>;
}
