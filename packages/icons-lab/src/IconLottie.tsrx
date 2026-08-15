/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLottie(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 22 18"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <rect width="22" height="18" fill="#F9FCFF" rx="2"/><path fill="#AEB2BE" fill-rule="evenodd" d="M18 0h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-2zm3 2v2h-2V2zm0 6V6h-2v2zm0 2v2h-2v-2zm0 6v-2h-2v2zM0 2a2 2 0 0 1 2-2h2v18H2a2 2 0 0 1-2-2zm3 0v2H1V2zm0 6V6H1v2zm0 2v2H1v-2zm0 6v-2H1v2z" clip-rule="evenodd"/><path stroke="#AEB2BE" d="M14.5 5c-2 0-4 .36-4 4 0 3.5-1.5 5-4 5"/><path fill="#F77C93" d="M14 4h2v2h-2z"/><path fill="#F8CE27" d="M6 13h2v2H6zM6.83 9.213a.02.02 0 0 1 .038-.007l.31.516a.02.02 0 0 0 .015.01l.594.099a.02.02 0 0 1 .007.037l-.516.31a.02.02 0 0 0-.01.014l-.099.594a.02.02 0 0 1-.037.007l-.31-.515a.02.02 0 0 0-.015-.01l-.594-.099a.02.02 0 0 1-.007-.037l.516-.31a.02.02 0 0 0 .01-.015z"/>
    </svg>;
}
