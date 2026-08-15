/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconShield(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 24 24"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="currentColor" fill-rule="evenodd" d="m2.682 3.795 8.743-2.623a2 2 0 0 1 1.15 0l8.732 2.62c.414.124.7.494.705.926C22.037 7.35 21.978 16.443 20 19c-1.975 2.553-6.382 3.657-7.651 3.93q-.35.075-.698-.002c-1.248-.277-5.53-1.382-7.65-3.928C1.865 16.44 1.917 7.322 1.978 4.706a.975.975 0 0 1 .703-.91M12 4.002v15.996l.009.002s3.964-.727 5.584-2.91c1.62-2.18 1.396-11.18 1.396-11.18L12.01 4z" clip-rule="evenodd"/>
    </svg>;
}
