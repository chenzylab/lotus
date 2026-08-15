/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFilterStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M12.566 12.064 19.766 4H4.246l7.254 8.059v6.391l1.066.695zm2 8.936-.01.129a1 1 0 0 1-1.319.815l-.119-.05-3.065-2A1 1 0 0 1 9.5 19v-6.174l-8.264-9.18A1 1 0 0 1 2 2h20a1 1 0 0 1 .764 1.646l-8.198 9.18z"/>
    </svg>;
}
