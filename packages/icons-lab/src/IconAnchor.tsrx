/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAnchor(props: { class?: string; style?: Record<string, any> }) {
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
        <path stroke="#AAB2BF" stroke-linejoin="round" stroke-width="2" d="M6.167 12h-2.5a8.333 8.333 0 1 0 16.666 0h-2.5"/><path stroke="#818A9B" stroke-linejoin="round" stroke-width="2" d="M12 20.333v-12.5"/><path fill="#324350" fill-rule="evenodd" stroke="#324350" stroke-linejoin="round" stroke-width="1.25" d="M12.002 9.837a3.085 3.085 0 1 0 0-6.17 3.085 3.085 0 0 0 0 6.17Z" clip-rule="evenodd"/>
    </svg>;
}
