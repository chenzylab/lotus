/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconIdCardStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M20 3a3 3 0 0 1 3 3v11a3 3 0 0 1-2.846 2.996L20 20H4l-.154-.004a3 3 0 0 1-2.842-2.842L1 17V6a3 3 0 0 1 3-3zM4 5a1 1 0 0 0-1 1v11a1 1 0 0 0 1 1h16a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1zm4 8.857c1.674 0 3.128.514 3.854 1.267.368.383-.013.876-.55.876H4.696c-.536 0-.917-.493-.549-.876.726-.753 2.18-1.267 3.854-1.267M17 13a1 1 0 1 1 0 2h-3a1 1 0 1 1 0-2zM8 7c1.591 0 2.348.733 2.388 2.628.403.151.433.638.285 1.182-.114.418-.363.739-.624.844C9.628 12.717 8.86 13.43 8 13.43s-1.628-.712-2.049-1.775c-.262-.105-.511-.426-.625-.844-.148-.545-.118-1.031.285-1.182C5.651 7.733 6.41 7 8 7m11 2a1 1 0 1 1 0 2h-5a1 1 0 1 1 0-2z"/>
    </svg>;
}
