/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLayers(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m21.212 15.049.254.14c.515.284.687.906.385 1.39a1.05 1.05 0 0 1-.385.362l-8.919 4.92a1.14 1.14 0 0 1-1.094 0l-8.919-4.92c-.515-.284-.687-.906-.385-1.39a1.05 1.05 0 0 1 .385-.363l.254-.14 8.665 4.78c.32.177.715.186 1.043.026l.051-.026zm0-4.065.254.14c.515.284.687.906.385 1.39a1.05 1.05 0 0 1-.385.362l-8.919 4.92a1.14 1.14 0 0 1-1.094 0l-8.919-4.92c-.515-.284-.687-.906-.385-1.39.093-.15.226-.275.385-.362l.254-.14 8.665 4.779c.32.177.715.186 1.043.027l.051-.027zM12.547 2.14l8.919 4.919c.515.284.687.907.385 1.39a1.05 1.05 0 0 1-.385.363l-8.919 4.919a1.14 1.14 0 0 1-1.094 0L2.534 8.81c-.515-.284-.687-.906-.385-1.39.093-.15.226-.274.385-.362l8.919-4.92a1.14 1.14 0 0 1 1.094 0" clip-rule="evenodd"/>
    </svg>;
}
