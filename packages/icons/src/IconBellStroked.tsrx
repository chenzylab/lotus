/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBellStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M10.012 2.782a2 2 0 0 1 3.977.005A7 7 0 0 1 19 9.5c0 3.352.717 5.573 1.395 6.928.34.68.673 1.149.91 1.439a4 4 0 0 0 .335.364l.008.007A1 1 0 0 1 21 20h-5.126a4.002 4.002 0 0 1-7.748 0H3a1 1 0 0 1-.64-1.768c1.049-.874 1.713-2.245 2.112-3.87.396-1.611.504-3.36.528-4.87.002-2.721 1.16-4.52 2.666-5.604.75-.54 1.569-.892 2.346-1.106M12 21a2 2 0 0 1-1.732-1h3.464A2 2 0 0 1 12 21m6.974-3H5.15c.6-.975.997-2.071 1.264-3.16.45-1.833.561-3.763.586-5.324V9.5c0-2.074.842-3.274 1.834-3.988C9.878 4.76 11.16 4.5 12 4.5a5 5 0 0 1 5 5c0 3.648.783 6.177 1.606 7.822q.185.369.368.678" clip-rule="evenodd"/>
    </svg>;
}
