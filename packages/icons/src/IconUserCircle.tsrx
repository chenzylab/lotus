/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUserCircle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 23c6.075 0 11-4.925 11-11S18.075 1 12 1 1 5.925 1 12s4.925 11 11 11m3.347-11.292c-.688 1.76-1.94 2.939-3.346 2.939s-2.658-1.178-3.346-2.939c-.428-.174-.836-.705-1.022-1.4-.241-.9-.193-1.706.466-1.956C8.163 5.214 9.402 4 12.001 4s3.837 1.215 3.901 4.353c.658.25.706 1.055.465 1.956-.186.693-.593 1.224-1.02 1.399m2.747 5.681c.511.29.556.979.106 1.356C16.627 20.061 14.542 21 12 21s-4.627-.939-6.2-2.255c-.45-.377-.405-1.067.106-1.356C7.623 16.42 9.926 16 12 16s4.377.42 6.094 1.39" clip-rule="evenodd"/>
    </svg>;
}
