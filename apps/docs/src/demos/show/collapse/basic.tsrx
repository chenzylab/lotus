import { Collapse, CollapsePanel } from '@lotus/ripple';

export function BasicCollapseDemo() @{
    <Collapse defaultActiveKey="1">
        <CollapsePanel itemKey="1" header="第一部分">
            这里是第一部分的内容。
        </CollapsePanel>
        <CollapsePanel itemKey="2" header="第二部分">
            这里是第二部分的内容。
        </CollapsePanel>
        <CollapsePanel itemKey="3" header="第三部分（禁用）" disabled>
            这部分内容不可展开。
        </CollapsePanel>
    </Collapse>
}
