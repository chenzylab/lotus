/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTooltip(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#6A6F7F" fill-rule="evenodd" d="M3.292 3.867A2.304 2.304 0 0 0 1.24 6.399l1.204 11.458a2.304 2.304 0 0 0 2.533 2.051l4.102-.431 3.464 2.805c.247.2.61.162.81-.085l2.805-3.464 4.287-.45a2.304 2.304 0 0 0 2.051-2.533L21.293 4.292A2.304 2.304 0 0 0 18.76 2.24z" clip-rule="evenodd"/><path fill="#fff" fill-rule="evenodd" d="M11.46 8.569c-.553.058-.953.567-.893 1.136.06.57-.34 1.079-.895 1.137-.553.058-1.05-.356-1.11-.926-.18-1.708 1.02-3.235 2.682-3.41 1.661-.174 3.153 1.07 3.333 2.778.092.875-.265 1.584-.584 2.051-.164.24-.337.443-.476.6l-.155.173a3 3 0 0 0-.122.14l-.596.756a.99.99 0 0 1-1.418.15 1.06 1.06 0 0 1-.153-1.459l.596-.757c.074-.094.185-.217.274-.316l.08-.09q.177-.195.318-.396c.193-.282.247-.485.23-.641-.06-.57-.556-.984-1.11-.926" clip-rule="evenodd"/><circle cx="12.057" cy="15.158" r="1.2" fill="#fff" transform="rotate(-6 12.057 15.158)"/>
    </svg>;
}
