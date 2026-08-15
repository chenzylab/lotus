/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconForm(props: { class?: string; style?: Record<string, any> }) {
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
        <g clip-path="url(#a)"><rect width="16" height="21" x="3.051" y="2.888" fill="#FF7D95" rx="2" transform="rotate(-6 3.05 2.888)"/><rect width="12" height="17" x="5.249" y="4.668" fill="#fff" rx="1" transform="rotate(-6 5.249 4.668)"/><path fill="#AAB2BF" fill-rule="evenodd" d="m12.31.91 1.576-.166a1 1 0 0 1 1.1.89l.313 2.983-7.957.837L7.03 2.47a1 1 0 0 1 .89-1.099l1.577-.166A1.5 1.5 0 0 1 12.309.91" clip-rule="evenodd"/><path fill="#DDE3E8" d="m7.656 8.437 7.956-.836.21 1.989-7.957.836zM8.074 12.415l7.956-.836.21 1.989-7.957.836zM8.492 16.393l3.332-.35.209 1.989-3.332.35z"/><path fill="#6A6F7F" d="m20.034 9.948-4.926 4.96a.9.9 0 0 0-.211.316l-.862 2.13c-.155.384.23.765.62.611l2.153-.852a1 1 0 0 0 .32-.208l4.926-4.96zM22.054 11.945l.667-.672a.934.934 0 0 0 0-1.331l-.673-.666a.96.96 0 0 0-1.347 0l-.667.672z"/></g><defs><clipPath id="a"><path fill="#fff" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
