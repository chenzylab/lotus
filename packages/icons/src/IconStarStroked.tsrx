/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconStarStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 5.029 9.569 9.102c-.173.289-.461.489-.791.55l-4.299.785 2.994 3.467c.219.254.318.59.273.922l-.611 4.46 4.405-1.894c.294-.126.626-.126.92 0l4.405 1.894-.61-4.46a1.17 1.17 0 0 1 .272-.922l2.994-3.467-4.299-.786c-.33-.06-.618-.26-.79-.549zm-1-2.46a1.164 1.164 0 0 1 2 0l3.028 5.072 5.515 1.008a1.168 1.168 0 0 1 .672 1.912l-3.803 4.405.782 5.706c.123.9-.781 1.59-1.614 1.232l-5.58-2.4-5.58 2.4a1.166 1.166 0 0 1-1.614-1.232l.782-5.706-3.803-4.405a1.168 1.168 0 0 1 .672-1.912L7.972 7.64z" clip-rule="evenodd"/>
    </svg>;
}
