/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGit(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="m22.585 11.019-9.606-9.605a1.42 1.42 0 0 0-2.005 0l-1.99 1.993 2.529 2.53a1.685 1.685 0 0 1 2.133 2.146l2.436 2.44a1.684 1.684 0 0 1 1.741 2.785c-.659.66-1.723.66-2.383 0a1.69 1.69 0 0 1-.37-1.83l-2.282-2.27v5.983c.16.078.314.186.448.32a1.69 1.69 0 0 1 0 2.383 1.69 1.69 0 0 1-2.392 0 1.68 1.68 0 0 1 0-2.382 1.7 1.7 0 0 1 .554-.373V9.1a1.682 1.682 0 0 1-.913-2.21L8 4.391l-6.586 6.582a1.427 1.427 0 0 0 0 2.006l9.605 9.605c.553.555 1.45.555 2.003 0l9.56-9.56c.558-.552.558-1.45.004-2.005"/>
    </svg>;
}
