/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDislikeThumb(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m16.941 13.786-3.713 6.963c-.127.238-.42.33-.64.175-.582-.41-1.421-1.2-1.421-2.123 0-.5.132-1.397.27-2.338.153-1.035.313-2.122.313-2.788H4.167c-.445 0-1.167-.451-1.167-1.5 0-.904.992-5.087 1.692-8.042L5 2.831c0-.219.267-.655 1.333-.655h10.169c.276 0 .498.223.498.5V13.55a.5.5 0 0 1-.059.235m4.559-.11a.5.5 0 0 0 .5-.5v-10.5a.5.5 0 0 0-.5-.5h-2a.5.5 0 0 0-.5.5v10.5a.5.5 0 0 0 .5.5z" clip-rule="evenodd"/>
    </svg>;
}
