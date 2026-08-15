/** 模块级自增计数器，为每次渲染生成唯一的本地 id 后缀（见 extractLocalIds/makeIdsUnique）。 */
let uidCounter = 0;

/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconNotification(props: { class?: string; style?: Record<string, any> }) {
    const uid = `lotus-iconnotification-${uidCounter++}`;
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
        <g clip-path={`url(#${uid}-a)`}><circle cx="13.062" cy="19.062" r="2.786" fill="#324350" transform="rotate(-6 13.062 19.062)"/><path fill="#FBCD2C" d="M11.164.963c-.994.105-1.936.707-1.832 1.701l.072.685c-2.504.933-3.663 3.417-3.37 6.198l.313 2.983c.279 2.65-1.151 3.779-2.365 5.34-.58.747.02 1.945.96 1.846l16.209-1.703c.94-.099 1.277-1.396.554-2.005-1.512-1.275-3.145-2.082-3.424-4.732l-.313-2.984c-.293-2.78-1.942-4.969-4.586-5.36l-.072-.686C13.206 1.251 12.16.859 11.164.963"/><path fill="#DDE3E8" fill-rule="evenodd" d="M18.423 4.909c-.317-.532-.843-.984-1.877-1.512a1 1 0 0 1 .909-1.782c1.185.605 2.091 1.273 2.685 2.27.583.977.788 2.144.859 3.572A1 1 0 0 1 19 7.556c-.066-1.331-.25-2.098-.579-2.647M3.355 12.679c.141-.674.106-1.395-.14-2.452a1 1 0 1 1 1.948-.454c.282 1.212.373 2.251.149 3.317-.221 1.052-.73 2.036-1.477 3.169a1 1 0 1 1-1.67-1.1c.696-1.056 1.045-1.792 1.19-2.48" clip-rule="evenodd"/></g><defs><clipPath id={`${uid}-a`}><path fill="#fff" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
