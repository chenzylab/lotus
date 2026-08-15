import { Tag, Space } from '@lotus/ripple';
import { IconGithubLogo, IconLotusLogo } from '@lotus/icons';

export function TagIconDemo() {
    return <Space>
        <Tag color="lightBlue" size="large" prefixIcon={<IconGithubLogo />}>
            Lotus Design
        </Tag>
        <Tag color="cyan" size="large" suffixIcon={<IconLotusLogo />}>
            D2C: figma to code in one click
        </Tag>
    </Space>;
}
