/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUser(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M12 16c1.982 0 3.745-1.66 4.714-4.141.602-.247 1.175-.995 1.437-1.97.34-1.27.272-2.404-.655-2.756C17.406 2.71 15.662 1 12 1 8.339 1 6.594 2.71 6.504 7.132c-.93.352-.997 1.486-.657 2.756.262.978.836 1.726 1.44 1.972C8.254 14.34 10.018 16 12 16M19.605 22c1.233 0 2.112-1.151 1.262-2.045C19.197 18.199 15.853 17 12 17s-7.197 1.198-8.867 2.955c-.85.894.028 2.045 1.262 2.045z"/>
    </svg>;
}
