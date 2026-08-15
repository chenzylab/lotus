/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMapPinStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M19 10c0 .953-.317 2.142-.937 3.471-.611 1.31-1.463 2.638-2.392 3.833-.93 1.198-1.9 2.21-2.715 2.902a7 7 0 0 1-.956.703 7 7 0 0 1-.956-.703c-.815-.692-1.784-1.704-2.715-2.902-.93-1.195-1.78-2.524-2.392-3.833C5.317 12.142 5 10.953 5 10c0-2.259.738-3.973 1.882-5.118C8.027 3.738 9.742 3 12 3s3.973.738 5.118 1.882C18.262 6.027 19 7.742 19 10m2 0c0 5.418-7 13-9 13s-9-7.582-9-13 3.582-9 9-9 9 3.582 9 9m-9 3a4 4 0 1 0 0-8 4 4 0 0 0 0 8m2-4a2 2 0 1 1-4 0 2 2 0 0 1 4 0" clip-rule="evenodd"/>
    </svg>;
}
