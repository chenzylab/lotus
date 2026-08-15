import { Dropdown, DropdownMenu, DropdownItem, Button, Space } from '@lotus/ripple';

export function DropdownTriggerDemo() {
    return <Space>
        <Dropdown
            trigger="hover"
            render={<DropdownMenu><DropdownItem>选项一</DropdownItem><DropdownItem>选项二</DropdownItem></DropdownMenu>}
        >
            <Button theme="outline">hover 触发</Button>
        </Dropdown>
        <Dropdown
            trigger="click"
            render={<DropdownMenu><DropdownItem>选项一</DropdownItem><DropdownItem>选项二</DropdownItem></DropdownMenu>}
        >
            <Button theme="outline">click 触发</Button>
        </Dropdown>
    </Space>;
}
