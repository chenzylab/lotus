import { Collapse, CollapsePanel } from '@lotus/ripple';

export function AccordionCollapseDemo() @{
    <Collapse accordion defaultActiveKey="1">
        <CollapsePanel itemKey="1" header="手风琴模式 - 一">
            同时只能展开一个面板，展开新面板会自动收起其他面板。
        </CollapsePanel>
        <CollapsePanel itemKey="2" header="手风琴模式 - 二">
            这里是第二个面板的内容。
        </CollapsePanel>
    </Collapse>
}
