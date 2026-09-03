package com.monu.mobile.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import kotlinx.coroutines.launch
import com.monu.mobile.ui.components.MONUSidebar
import com.monu.mobile.ui.navigation.MONUDestination
import com.monu.mobile.ui.screens.ChatScreen
import com.monu.mobile.ui.screens.FeatureScreen
import com.monu.mobile.ui.screens.HomeScreen
import com.monu.mobile.ui.screens.ConnectionScreen

@Composable
fun MONUApp() {
    MaterialTheme(
        colorScheme = darkColorScheme(
            primary = Color(0xFF4FC3F7),
            secondary = Color(0xFF80CBC4),
            background = Color(0xFF0B1020),
            surface = Color(0xFF121A2B)
        )
    ) {
        MONURoot()
    }
}

@Composable
private fun MONURoot() {
    var currentDestination by remember {
        mutableStateOf(MONUDestination.HOME)
    }

    val drawerState = rememberDrawerState(
        initialValue = DrawerValue.Closed
    )

    val scope = rememberCoroutineScope()

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            MONUSidebar(
                current = currentDestination,
                onNavigate = { destination ->
                    currentDestination = destination
                    scope.launch {
                        drawerState.close()
                    }
                },
                onNewChat = {
                    currentDestination = MONUDestination.CHAT
                    scope.launch {
                        drawerState.close()
                    }
                }
            )
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Text(
                            text = currentDestination.title
                        )
                    },
                    navigationIcon = {
                        IconButton(
                            onClick = {
                                scope.launch {
                                    drawerState.open()
                                }
                            }
                        ) {
                            Text("☰")
                        }
                    }
                )
            }
        ) {
            Surface(
                modifier = Modifier.fillMaxSize()
            ) {
                when (currentDestination) {

                    MONUDestination.HOME -> {
                        HomeScreen(
                            onOpenCommand = {
                                currentDestination =
                                    MONUDestination.CHAT
                            }
                        )
                    }

                    MONUDestination.CHAT -> {
                        ChatScreen()
                    }

                    MONUDestination.CONNECTION -> {
                        ConnectionScreen()
                    }

                    else -> {
                        FeatureScreen(
                            title = currentDestination.title,
                            description =
                                "MONU ${currentDestination.title} module."
                        )
                    }
                }
            }
        }
    }
}
