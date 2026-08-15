import { Layout, Header, Footer, Sider, Content } from '@lotus/ripple';

export function RightSiderLayoutDemo() {
    const commonStyle = { height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)' };

    return <Layout style={{ border: '1px solid var(--lotus-color-border)' }}>
        <Header style={commonStyle}>Header</Header>
        <Layout hasSider>
            <Content style={{ height: '300px', lineHeight: '300px' }}>Content</Content>
            <Sider style={{ width: '120px', background: 'var(--lotus-color-fill-2)' }}>Sider</Sider>
        </Layout>
        <Footer style={commonStyle}>Footer</Footer>
    </Layout>;
}
