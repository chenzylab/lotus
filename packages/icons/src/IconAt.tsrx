/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAt(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 12a8 8 0 1 1 16 0 8 8 0 0 1-.47 2.71q-.037.061-.077.12c-.269.39-.672.67-1.453.67-.327 0-.633-.127-.906-.505a2 2 0 0 1-.094-.142V9.5a1.5 1.5 0 0 0-2.57-1.052 5 5 0 1 0 0 8.103q.102.104.22.185l.014.018C15.476 17.878 16.67 18.5 18 18.5c1.719 0 3.066-.727 3.922-1.965q.064-.093.123-.188a1.5 1.5 0 0 0 .22-.389l.002-.002c.537-1.048.733-2.273.733-3.456h-.011q.01-.249.011-.5c0-6.075-4.925-11-11-11S1 5.925 1 12s4.925 11 11 11c.792 0 1.567-.084 2.314-.244a1.5 1.5 0 1 0-.628-2.934A8 8 0 0 1 4 12m9.5.5a2 2 0 1 0-4 0 2 2 0 0 0 4 0" clip-rule="evenodd"/>
    </svg>;
}
