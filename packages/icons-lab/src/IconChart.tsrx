/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconChart(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#4CC3FA" d="M21.905 11.25c.579 0 1.041-.491.946-1.062a11.01 11.01 0 0 0-9.039-9.04c-.57-.094-1.062.368-1.062.947v4.1c0 .495.367.905.836 1.062a5.01 5.01 0 0 1 3.157 3.157c.157.47.567.836 1.062.836z" style="fill:#4cc3fa;fill:color(display-p3 .298 .7647 .9804);fill-opacity:1"/><path fill="#6A6F7F" d="M17.805 12.75c-.495 0-.905.367-1.062.836a5.002 5.002 0 0 1-6.976 2.889c-.442-.221-.991-.19-1.34.16L6.24 18.82c-.411.41-.388 1.09.09 1.42A9.95 9.95 0 0 0 12 22c4.902 0 8.98-3.527 9.835-8.182.105-.572-.358-1.068-.94-1.068z" style="fill:#6a6f7f;fill:color(display-p3 .4157 .4353 .498);fill-opacity:1"/><path fill="#DDE3E8" d="M8.426 7.366c.35.35.899.38 1.341.159a5 5 0 0 1 .647-.268c.47-.157.836-.567.836-1.062v-3.09c0-.582-.496-1.045-1.068-.94a9.95 9.95 0 0 0-3.85 1.595c-.48.33-.502 1.01-.091 1.42z" style="fill:#dde3e8;fill:color(display-p3 .8667 .8902 .9098);fill-opacity:1"/><path fill="#AAB2BF" d="M7.365 15.574c.35-.35.381-.899.16-1.341A5 5 0 0 1 7 12c0-.802.189-1.56.525-2.233.221-.442.19-.991-.16-1.34L5.18 6.24c-.41-.411-1.09-.388-1.42.09A9.95 9.95 0 0 0 2 12c0 2.105.65 4.057 1.76 5.668.33.48 1.009.502 1.42.091z" style="fill:#aab2bf;fill:color(display-p3 .6667 .698 .749);fill-opacity:1"/>
    </svg>;
}
