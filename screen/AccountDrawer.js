import React from 'react'
import { ScrollView, SafeAreaView, StyleSheet, Text, View } from 'react-native'
import Ripple from 'react-native-material-ripple'
import Jazzicon from '@novaviva/react-native-jazzicon'


export default function AccountDrawer(props) {
    const [accounts, setAccounts] = React.useState(props.accounts)
    React.useEffect(() => {
        setAccounts(props.accounts)
    }, [props.accounts])
    return (
        <ScrollView
            style={[styles.container,
            { height: global.screenHeight }
            ]}
        >
            <SafeAreaView
                forceInset={{ top: 'always', horizontal: 'never' }}
            >
                <Text style={styles.title}>📒账户列表 </Text>
                {accounts.map((item, index) => {
                    return (
                        <Ripple
                            rippleColor='#999'
                            rippleOpacity={0.6}
                            style={styles.itemView}
                            onPress={() => { props.selectAccounts(accounts,index) }}
                            key={index}
                        >
                            <Jazzicon size={16} address={item.address} />
                            <Text style={styles.itemText}>
                                账户{index + 1}
                            </Text>
                        </Ripple>
                    )
                })}

                <Ripple
                    rippleColor='#999'
                    rippleOpacity={0.6}
                    style={[styles.itemView,{borderBottomWidth:0}]}
                    onPress={() => { props.addAccounts() }}
                >
                    <Text style={styles.addText}>
                    ➕添加账户
                    </Text>
                </Ripple>
            </SafeAreaView>
        </ScrollView>
    )
}

const styles = StyleSheet.create({
    title: {
        textAlign: 'center',
        fontSize: 14,
        color: '#ddd',
        lineHeight: 50,
        borderBottomWidth: 0.5,
        borderBottomColor: '#999',
        fontFamily: 'BigYoungMediumGB2.0',
        letterSpacing: 1
    },
    container: {
        backgroundColor: '#333',
        flex: 1,
    },
    itemView: {
        borderBottomWidth: 0.5,
        borderBottomColor: '#999',
        flexDirection: 'row',
        padding: 10,
        alignItems: 'center',
        justifyContent: 'center',
        height:40
    },
    itemText: {
        textAlign: 'center',
        fontSize: 16,
        color: '#ddd',
        lineHeight: 20,
        fontFamily: 'BigYoungMediumGB2.0',
        letterSpacing: 2,
        marginLeft: 8
    },
    addText: {
        textAlign: 'center',
        fontSize: 12,
        color: '#ddd',
        lineHeight: 20,
        fontFamily: 'BigYoungMediumGB2.0',
        letterSpacing: 2
    }
})