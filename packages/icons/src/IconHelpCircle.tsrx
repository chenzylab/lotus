/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHelpCircle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 23c6.075 0 11-4.925 11-11S18.075 1 12 1 1 5.925 1 12s4.925 11 11 11m-.172-8.39c-.86 0-1.289-.538-1.289-1.24 0-1.046.518-1.72 1.729-2.638l.065-.05c.824-.626 1.4-1.064 1.4-1.854 0-.889-.83-1.406-1.758-1.406-.762 0-1.348.283-1.807.879-.332.342-.596.527-1.045.527C8.381 8.828 8 8.311 8 7.715c0-.606.342-1.22.879-1.69C9.602 5.4 10.754 5 12.277 5c2.715 0 4.62 1.338 4.62 3.643 0 1.68-1.006 2.49-2.188 3.31-.8.586-1.182.928-1.484 1.621l-.001.002c-.332.585-.586 1.033-1.396 1.033m-.02 4.16c-.937 0-1.708-.606-1.708-1.543 0-.938.771-1.543 1.709-1.543.937 0 1.699.605 1.699 1.543s-.762 1.543-1.7 1.543" clip-rule="evenodd"/>
    </svg>;
}
