/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAvatar(props: { class?: string; style?: Record<string, any> }) {
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
        <circle cx="12" cy="12" r="11" fill="#FBCD2C"/><mask id="a" width="22" height="22" x="1" y="1" maskUnits="userSpaceOnUse" style="mask-type:alpha"><circle cx="12" cy="12" r="11" fill="#A2845E"/></mask><g mask="url(#a)"><path fill="#fff" fill-rule="evenodd" d="M12 17.796c1.718 0 3.248-1.44 4.088-3.591.522-.214 1.02-.863 1.246-1.71.295-1.1.236-2.083-.567-2.39-.078-3.834-1.592-5.318-4.767-5.318S7.31 6.271 7.233 10.105c-.806.305-.865 1.289-.57 2.39.228.849.725 1.498 1.248 1.71.84 2.152 2.37 3.591 4.089 3.591M20.013 23c.327 0 .578-.296.456-.6-.86-2.137-4.325-3.736-8.469-3.736S4.39 20.262 3.531 22.4c-.122.304.129.6.456.6z" clip-rule="evenodd"/></g>
    </svg>;
}
