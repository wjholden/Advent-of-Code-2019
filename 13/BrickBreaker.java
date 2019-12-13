import java.net.Socket;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.WindowEvent;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.UnknownHostException;
import java.util.Scanner;

import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import javax.swing.*;

public class BrickBreaker extends JFrame implements KeyListener {

    private static final int TIMER_DELAY_MILLISECONDS = 1000;
    private final JLabel score = new JLabel("0");
    private int joystick = 0;
    private final String symbols[] = new String[] { " ", "■", "□", "_", "∘"};
    private final Socket socket;
    private final JTextArea textArea = new JTextArea(20, 42);
    private final int values[][] = new int[42][20];
    private final javax.swing.Timer timer;

    public BrickBreaker(Socket socket) {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.add(score);
        textArea.setEditable(false);
        panel.add(textArea);
        add(panel);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        pack();
        setVisible(true);
        setTitle("Advent of Code 2019 Day 13 Intcode Brick Breaker");
        timer = new javax.swing.Timer(TIMER_DELAY_MILLISECONDS, this::updateScreen);
        timer.start();
        this.socket = socket;
    }

    private void updateScreen(ActionEvent e) {
        Scanner sc = new Scanner(socket);
        i = 0;
        while (sc.hasNextInt()) {
            int x = sc.nextInt();
            int y = sc.nextInt();
            int v = sc.nextInt();
            if (x == -1 && y == 0) {
                score = v;
            } else {
                values[x][y] = v;
            }
        }
        
    }

    public static void main (String args[]) {
        SwingUtilities.invokeLater(() -> createAndShowGui());
    }

    private static void createAndShowGui() {
        BrickBreaker frame;
        try (Socket socket = new Socket("localhost", 60000)) {
            frame = new BrickBreaker(socket);
            frame.addKeyListener(frame);
        } catch (IOException ex) {
            System.err.println(ex);
        }
        System.out.println("done");
    }

    public void keyPressed(KeyEvent e) {
        switch (e.getKeyCode()) {
            case KeyEvent.VK_LEFT:
                this.joystick = -1;
                break;
            case KeyEvent.VK_RIGHT:
                this.joystick = 1;
                break;
            default:
                this.joystick = 0;
                break;
        }
        System.out.println(this.joystick);
    }

    public void keyTyped(KeyEvent e) {
        System.out.println(e.getKeyCode());
    }

    public void keyReleased(KeyEvent e) {
    
        System.out.println(e.getKeyCode());
    }
}