import { Layout, Header, Footer, Sider, Content } from '@lotus/ripple';

export function LeftSiderLayoutDemo() {
    const commonStyle = { height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)' };

    return <Layout style={{ border: '1px solid var(--lotus-color-border)' }}>
        <Header style={commonStyle}>Header</Header>
        <Layout hasSider>
            <Sider style={{ width: '120px', background: 'var(--lotus-color-fill-2)' }}>Sider</Sider>
            <Content style={{ height: '300px', lineHeight: '300px' }}>Content</Content>
        </Layout>
        <Footer style={commonStyle}>Footer</Footer>
    </Layout>;
}
