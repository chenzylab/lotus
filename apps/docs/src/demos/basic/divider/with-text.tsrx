import { Divider } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';

export function WithTextDividerDemo() {
    return <div>
        <Divider margin="12px" align="left">
            这是居左文字
        </Divider>

        <Divider margin="12px" align="center">
            这是居中文字
        </Divider>

        <Divider margin="12px" align="right">
            这是居右文字
        </Divider>

        <Divider margin="12px">
            <IconLotusLogo />
        </Divider>
    </div>;
}
