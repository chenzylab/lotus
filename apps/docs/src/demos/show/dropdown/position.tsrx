import { Dropdown, DropdownMenu, DropdownItem, Button, Space } from '@lotus/ripple';
import type { FloatingPosition } from '@lotus/ripple';

const POSITIONS: FloatingPosition[] = ['bottomLeft', 'bottom', 'bottomRight'];

export function DropdownPositionDemo() @{
    <Space>
        @for (const position of POSITIONS; key position) {
            <Dropdown
                trigger="click"
                position={position}
                render={
                    <DropdownMenu>
                        <DropdownItem>选项一</DropdownItem>
                        <DropdownItem>选项二</DropdownItem>
                    </DropdownMenu>
                }
            >
                <Button theme="outline">{position}</Button>
            </Dropdown>
        }
    </Space>
}
