/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconEyedropper(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M1.224 20.766a4.236 4.236 0 0 1 .02-5.976l9.326-9.281-.945-.952a1.41 1.41 0 0 1 0-1.986 1.385 1.385 0 0 1 1.97 0l.958.965 2.332-2.321a4.155 4.155 0 0 1 5.891.019 4.236 4.236 0 0 1-.02 5.976l-2.293 2.283 1.012 1.02a1.41 1.41 0 0 1 0 1.987 1.385 1.385 0 0 1-1.97 0l-1.025-1.034-9.365 9.32a4.155 4.155 0 0 1-5.891-.02M12.54 7.495l1.97 1.985-9.353 9.307a1.385 1.385 0 0 1-1.963-.006 1.41 1.41 0 0 1 .006-1.993z" clip-rule="evenodd"/>
    </svg>;
}
