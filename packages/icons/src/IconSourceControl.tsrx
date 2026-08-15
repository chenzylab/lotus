/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSourceControl(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M7 3a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3M2.5 4.5a4.5 4.5 0 1 1 6 4.244v4.225c1.176-.338 2.622-.43 3.867-.51l.285-.018c1.494-.098 2.697-.204 3.531-.512q.038-.014.073-.028a4.5 4.5 0 1 1 3.538.41q-.21.623-.635 1.136c-.539.647-1.248 1.042-1.936 1.296-1.322.489-2.994.601-4.375.691l-.11.007c-1.296.085-2.37.155-3.186.352a4.5 4.5 0 1 1-4.052-.537V8.744a4.5 4.5 0 0 1-3-4.244m16 2a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3M7 18a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3" clip-rule="evenodd"/>
    </svg>;
}
