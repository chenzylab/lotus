/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGift(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 4.5C4 2.599 5.416 1 7.5 1c.965 0 1.785.48 2.414 1.027.637.554 1.18 1.264 1.612 1.928.172.265.33.529.474.781a15 15 0 0 1 .474-.781c.432-.664.975-1.374 1.612-1.928C14.716 1.479 15.536 1 16.5 1 18.584 1 20 2.599 20 4.5A3.5 3.5 0 0 1 18.95 7H21a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h-8V6h-2v5H3a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1h2.05A3.5 3.5 0 0 1 4 4.5m7 7.5H4v8a2 2 0 0 0 2 2h5zm2 10h5a2 2 0 0 0 2-2v-8h-7zM10.414 6c-.164-.303-.354-.63-.565-.955-.38-.586-.806-1.126-1.247-1.51C8.152 3.146 7.785 3 7.5 3 6.584 3 6 3.64 6 4.5A1.5 1.5 0 0 0 7.5 6zm3.737-.955c-.211.325-.401.652-.565.955H16.5A1.5 1.5 0 0 0 18 4.5c0-.86-.584-1.5-1.5-1.5-.285 0-.653.146-1.102.536-.44.383-.866.923-1.247 1.509" clip-rule="evenodd"/>
    </svg>;
}
