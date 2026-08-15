/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconForwardStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m20.122 12-5.683 5.983v-1.485a3 3 0 0 0-3.009-2.999c-2.306.01-4.44.063-6.26.85a7.3 7.3 0 0 0-1.243.688c.352-1.13.911-2.108 1.64-2.906 1.3-1.42 3.276-2.423 6-2.6 1.514-.099 2.872-1.335 2.872-3.028v-.486zm-16.6 6.25c1.809-2.528 3.934-2.734 7.917-2.75a1 1 0 0 1 1 .998v4c0 .902 1.094 1.343 1.713.69l8.073-8.498a1.003 1.003 0 0 0 0-1.38l-8.073-8.499c-.619-.652-1.713-.211-1.713.69v3.002c0 .552-.45.996-1.002 1.032-6.217.404-9.798 4.593-9.933 10.133a4.55 4.55 0 0 0 .026.77c.038.353.109.805.203 1.178.09.358.2.644.323.696.137.06.288-.014.438-.317q.361-.726.729-1.303.147-.232.298-.442" clip-rule="evenodd"/>
    </svg>;
}
